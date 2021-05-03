defmodule Weather.Forecast do
  @options [timeout: 50_000, recv_timeout: 50_000]
  def get(area \\ 400_000) do
    "https://www.jma.go.jp/bosai/forecast/data/overview_forecast/#{area}.json"
    |> HTTPoison.get!([], @options)
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
