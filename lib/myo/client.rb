class Myo::Client
  def initialize(socket_url)
    @socket_url = socket_url
    @__callbacks = {}
    @__pool      = {}
  end

  def on(event_name, &block)
    @__callbacks[event_name.to_sym] = block
  end

  def start
    EM.run do
      conn = EventMachine::WebSocketClient.connect(@socket_url)

      @__callbacks[:connected] &&
      conn.callback do
        instance_eval(&@__callbacks[:connected])
      end

      @__callbacks[:error] &&
      conn.errback do |e|
        instance_eval(e, &@__callbacks[:error])
      end

      conn.stream do |msg|
        conn.close_connection if msg.data == "done"

        event = JSON.parse(msg.data)[1]
        case event['type']
        when 'pose'
          break unless @__callbacks[:pose]
          pose = event['pose']
          instance_eval(@__pool[:prev_pose], :off, &@__callbacks[:pose]) if @__pool[:prev_pose]
          instance_eval(pose, :on, &@__callbacks[:pose])
          @__pool[:prev_pose] = pose
        when 'orientation'
          break unless @__callbacks[:periodic]
          e = OpenStruct.new({
            :accel => OpenStruct.new({
              :x => event['accelerometer'][0],
              :y => event['accelerometer'][1],
              :z => event['accelerometer'][2]
            }),
            :gyro => OpenStruct.new({
              :x => event['gyroscope'][0],
              :y => event['gyroscope'][1],
              :z => event['gyroscope'][2]
            }),
            :orientation => OpenStruct.new(event['orientation'])
          })
          @__pool[:latest_orientation] = e
          instance_eval(e, &@__callbacks[:periodic])
        end
      end

      conn.disconnect do
        EM::stop_event_loop
      end
    end
  end
end
