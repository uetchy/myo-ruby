class Myo::Chamber
  attr_accessor :callbacks_

  def initialize(socket_url)
    @socket_url = socket_url
    @callbacks_ = {}
    @pool_      = {}
  end

  def getRoll
    @pool_[:latest_orientation].accel.x
  end

  def start
    EM.run do
      conn = EventMachine::WebSocketClient.connect(@socket_url)

      conn.callback do
        return unless @callbacks_[:connected]
        instance_eval(&@callbacks_[:connected])
      end

      conn.errback do |e|
        return unless @callbacks_[:error]
        instance_eval(e, &@callbacks_[:error])
      end

      conn.stream do |msg|
        conn.close_connection if msg.data == "done"

        event = JSON.parse(msg.data)[1]
        case event['type']
        when 'pose'
          break unless @callbacks_[:pose]
          pose = event['pose']
          instance_eval(@pool_[:prev_pose], :off, &@callbacks_[:pose]) if @pool_[:prev_pose]
          instance_eval(pose, :on, &@callbacks_[:pose])
          @pool_[:prev_pose] = pose
        when 'orientation'
          break unless @callbacks_[:periodic]
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
          @pool_[:latest_orientation] = e
          instance_eval(e, &@callbacks_[:periodic])
        end
      end

      conn.disconnect do
        EM::stop_event_loop
      end
    end
  end
end

class Myo::Client
  def initialize(socket_url)
    @socket_url = socket_url
    @chamber = Myo::Chamber.new(@socket_url)
  end

  def on(event_name, &block)
    @chamber.callbacks_[event_name.to_sym] = block
  end

  def start
    @chamber.start
  end
end
