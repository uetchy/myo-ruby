class Myo::Client
  MYO_VIBRATION_TYPES = {
    :short => 0,
    :medium => 1,
    :long => 2
  }

  MYO_UNLOCK_TYPES = {
    :timed => 0,
    :hold => 1
  }

  def initialize(socket_url)
    @__socket_url = socket_url
    @__callbacks  = {}
    @__event_pool = {}
    @__conn       = nil
  end

  def on(event_name, &block)
    @__callbacks[event_name.to_sym] = block
  end

  def send_command(data)
    @__conn.send(data.to_json)
  end

  def vibrate(vibration_type)
    vibration_int = MYO_VIBRATION_TYPES[vibration_type]
    send_command({:command => :vibrate, :args => vibration_int})
  end

  # getArm
  def arm()
    # left, right, unknown
    @__event_pool[:arm_synced]['arm'].to_sym
  end

  # getXDirection
  def x_direction()
    # towardWrist, towardElbow
    @__event_pool[:arm_synced]['x_direction'].to_sym
  end

  # getOrientationWorld
  def orientation()
    # Unit vector representing Myo's orientation. (Returns 3 values). Delimit return values as follows: x,y,z = myo.getOrientationWorld().
    @__event_pool[:orientation].orientation
  end

  # getRoll
  def roll() # TODO:
    # Get an angular value for Myo's orientation about its X axis, i.e. the wearer's arm. Positive roll indicates clockwise rotation (from the point of view of the wearer).
    @__event_pool[:orientation].gyro.x
  end

  # getPitch
  def pitch() # TODO:
    # Get an angular value for Myo's orientation about its Y axis. Positive pitch indicates the wearer moving their arm upwards, away from the ground.
    @__event_pool[:orientation].gyro.y
  end

  # getYaw
  def yaw() # TODO:
    # Get an angular value for Myo's orientation about its Z axis. Positive yaw indicates rotation to the wearer's right.
    @__event_pool[:orientation].gyro.z
  end

  # getGyro
  def gyro()
    # Angular velocity of Myo about its X, Y and Z axes. (Returns 3 values). Delimit return values as follows: x,y,z = myo.getGyro().
    @__event_pool[:orientation].gyro
  end

  # getAccel
  def accel()
    # Acceleration of Myo along its X, Y and Z axes in its own reference frame. (Returns 3 values). Delimit return values as follows: x,y,z = myo.getAccel().
    @__event_pool[:orientation].accel
  end

  # setLockingPolicy
  def locking_policy=(locking_policy) # TODO:
    # The new locking policy. Either "none" or "standard".
    # "none" : Don't use any locking mechanism; Myo is always unlocked. With this policy, the myo.unlock() and myo.lock() functions have no effect.
    # "standard" : Use Myo's built-in locking mechanism. This is the default.
  end

  def unlock(unlock_type)
    # "timed" : Unlock for a fixed period of time, after which it will automatically re-lock.
    # "hold" : Unlock until a lock() command is explicitly issued.
    unlock_int = MYO_UNLOCK_TYPES[unlock_type]
    send_command({:command => :unlock, :args => unlock_int})
  end

  def lock()
    # Force Myo to re-lock immediately. Pose events will not be delivered while to the script while Myo is locked.
    send_command({:command => :lock})
  end

  # isUnlocked
  def unlocked?() # TODO:
    # true if Myo is currently unlocked, otherwise false.
    @__event_pool[:unlocked]
  end

  # notifyUserAction
  def notify_user_action() # TODO:
    # Notify the connected Myo that a user action was recognized. Will cause Myo to vibrate.
  end

  # Supported callback functions
  # - connection_established
  # - connected
  # - pose
  # - periodic

  # Under working
  # - unlock
  # - lock
  # - active_change

  def start
    EM.run do
      @__conn = EventMachine::WebSocketClient.connect(@__socket_url)

      @__callbacks[:connection_established] &&
      @__conn.callback do
        instance_eval(&@__callbacks[:connection_established])
      end

      @__callbacks[:error] &&
      @__conn.errback do |e|
        instance_eval(e, &@__callbacks[:error])
      end

      @__conn.stream do |msg|
        @__conn.close_connection if msg.data == "done"

        event = JSON.parse(msg.data)[1]
        case event['type']
        when 'paired'
          @__event_pool[:paired] = event

        when 'connected'
          break unless @__callbacks[:connected]
          instance_eval(&@__callbacks[:connected])
          @__event_pool[:connected] = event

        when 'arm_synced'
          @__event_pool[:arm_synced] = event

        when 'unlocked'
          @__event_pool[:unlocked] ||= false
          @__event_pool[:unlocked] = true

        when 'pose'
          break unless @__callbacks[:pose]
          pose = event['pose']
          instance_eval(@__event_pool[:pose][:pose], :off, &@__callbacks[:pose]) if @__event_pool[:pose][:pose]
          instance_eval(pose, :on, &@__callbacks[:pose])
          @__event_pool[:pose] = event

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
          @__event_pool[:orientation] = e
          instance_eval(e, &@__callbacks[:periodic])

        end
      end

      @__conn.disconnect do
        EM::stop_event_loop
      end
    end
  end
end
