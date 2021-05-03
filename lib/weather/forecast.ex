defmodule Weather.Forecast do
  def get(area \\ 400_000) do
    "https://www.jma.go.jp/bosai/forecast/data/overview_forecast/#{area}.json"
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
