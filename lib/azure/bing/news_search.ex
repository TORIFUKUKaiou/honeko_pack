defmodule Azure.Bing.NewsSearch do
  @subscription_key System.get_env("AZURE_BING_SUBSCRIPTION_KEY")

  def top_news do
    search()
    |> Map.get("value")
    |> Enum.at(0)
  end

  def search do
    "https://api.bing.microsoft.com/v7.0/news/search?q=&setLang=ja-JP&mkt=ja-JP"
    |> HTTPoison.get!("Ocp-Apim-Subscription-Key": @subscription_key)
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
