require 'myo'

enableSphero = false

Sphero.start('/dev/tty.Sphero-XXX-XXX-SPP') do
  Myo.connect do |myo|
    myo.on :pose do |pose, edge|
      if pose == :fist and edge == :on
        enableSphero = true
      elsif pose == :fist and edge == :off
        enableSphero = false
      end
    end

    myo.on :periodic do
      return unless enableSphero

      roll(100, 0)
      keep_going(1)
    end
  end
end
