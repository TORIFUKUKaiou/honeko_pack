defmodule HonekoPack.Worker do
  @url "https://aht20.torifuku-kaiou.tokyo/api/values"
  @headers [{"Content-Type", "application/json"}]
  @options [timeout: 50_000, recv_timeout: 50_000]

  def run do
    aht20()
  end

  defp aht20 do
    {:ok, {temperature, humidity}} = aht20_read(:os.type())
    time = DateTime.utc_now() |> DateTime.to_unix()
    HonekoPack.Worker.Aht20Agent.update(temperature, humidity, time)
    post()
  end

  defp aht20_read({:unix, :darwin}) do
    # debug on macOS
    temperature = 10..20 |> Enum.random()
    humidity = 20..50 |> Enum.random()
    {:ok, {temperature, humidity}}
  end

  defp aht20_read(_) do
    Aht20.Reader.read()
  end

  defp post do
    %{temperature: temperature, humidity: humidity, time: time} =
      HonekoPack.Worker.Aht20Agent.get()

    json = Jason.encode!(%{value: %{temperature: temperature, humidity: humidity, time: time}})
    HTTPoison.post(@url, json, @headers, @options)
  end
end
