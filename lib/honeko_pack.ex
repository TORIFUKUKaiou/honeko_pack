defmodule HonekoPack do
  @moduledoc """
  Documentation for `HonekoPack`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> HonekoPack.hello()
      :world

  """
  def hello do
    :world
  end

  @default_voice_path "output"

  def run do
    func1 = &make_top_news/0
    func2 = &make_weather_forecast/0
    me = self()

    [func1, func2]
    |> Enum.map(fn f ->
      spawn_link(fn -> send(me, {self(), f.()}) end)
    end)
    |> Enum.map(fn pid ->
      receive do
        {^pid, result} ->
          result
      end
    end)
    |> Enum.map(fn text ->
      make_voice_file(text)
      play()
    end)
  end

  def play_top_news do
    make_top_news_voice()
    play()
  end

  def play_weather_forecast do
    make_weather_forecast_voice()
    play()
  end

  def make_weather_forecast_voice do
    make_weather_forecast()
    |> make_voice_file()
  end

  def make_weather_forecast do
    Weather.Forecast.get()
    |> Map.get("text")
  end

  def make_top_news_voice do
    make_top_news()
    |> make_voice_file()
  end

  def make_top_news do
    Azure.Bing.NewsSearch.top_news()
    |> Map.get("description")
  end

  def play(path \\ @default_voice_path) do
    do_play(path, :os.type())
  end

  def make_voice_file(text \\ "hello", path \\ @default_voice_path) do
    Azure.CognitiveServices.TextToSpeech.ssml(text, select_voice())
    |> Azure.CognitiveServices.TextToSpeech.to_speech_of_neural_voice()
    |> (&File.write(path, &1)).()
  end

  def select_voice(opts \\ []) do
    locale = Keyword.get(opts, :locale) || "ja-JP"
    voice_type = Keyword.get(opts, :voice_type) || "Neural"
    gender = Keyword.get(opts, :gender) || "Female"

    Azure.CognitiveServices.TextToSpeech.voices_list()
    |> Enum.filter(fn %{"Locale" => l} -> l == locale end)
    |> Enum.filter(fn %{"VoiceType" => vt} -> vt == voice_type end)
    |> Enum.filter(fn %{"Gender" => g} -> g == gender end)
    |> Enum.random()
  end

  defp do_play(path, {:unix, :darwin}) do
    :os.cmd('afplay #{path}')
  end

  defp do_play(path, _) do
    :os.cmd('aplay #{path}')
  end
end
