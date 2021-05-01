defmodule Aht20.Reader do
  alias Circuits.I2C

  @i2c_bus "i2c-1"
  @i2c_addr 0x38
  @initialization_command <<0xBE, 0x08, 0x00>>
  @trigger_measurement_command <<0xAC, 0x33, 0x00>>
  @two_pow_20 :math.pow(2, 20)

  def read do
    {:ok, ref} = I2C.open(@i2c_bus)

    I2C.write(ref, @i2c_addr, @initialization_command)
    Process.sleep(10)

    I2C.write(ref, @i2c_addr, @trigger_measurement_command)
    Process.sleep(80)

    ret = I2C.read(ref, @i2c_addr, 7)

    I2C.close(ref)

    value(ret)
  end

  defp value({:ok, val}), do: {:ok, convert(val)}

  defp value(_), do: :error

  defp convert(<<_, raw_humi::20, raw_temp::20, _>>) do
    humi = Float.round(raw_humi * 100 / @two_pow_20, 1)
    temp = Float.round(raw_temp * 200 / @two_pow_20 - 50.0, 1)

    {temp, humi}
  end
end
