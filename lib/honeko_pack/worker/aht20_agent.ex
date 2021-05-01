defmodule HonekoPack.Worker.Aht20Agent do
  use Agent

  def start_link(_initial_value) do
    Agent.start_link(fn -> %{temperature: 0, humidity: 0, time: 0} end, name: __MODULE__)
  end

  def get, do: Agent.get(__MODULE__, & &1)

  def update(temp, hum, time) do
    Agent.update(__MODULE__, fn _ ->
      %{temperature: temp, humidity: hum, time: time}
    end)
  end
end
