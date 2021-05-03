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
    me = self()

    [&make_top_news_voice_file/0, &make_weather_forecast_voice_file/0]
    |> Enum.map(fn f ->
      spawn_link(fn -> send(me, {self(), f.()}) end)
    end)
    |> Enum.map(fn pid ->
      receive do
        {^pid, result} ->
          result
      end
    end)
    |> Enum.map(&play/1)
  end

  def make_weather_forecast_voice do
    make_weather_forecast()
    |> make_voice()
  end

  def make_weather_forecast do
    Weather.Forecast.get()
    |> Map.get("text")
  end

  def make_weather_forecast_voice_file do
    do_something_and_create_file(:make_weather_forecast_voice)
  end

  def make_top_news_voice do
    make_top_news()
    |> make_voice()
  end

  def make_top_news do
    Azure.Bing.NewsSearch.top_news()
    |> Map.get("description")
  end

  def make_top_news_voice_file do
    do_something_and_create_file(:make_top_news_voice)
  end

  def play(path \\ @default_voice_path) do
    do_play(path, :os.type())
  end

  def make_voice(text) do
    Azure.CognitiveServices.TextToSpeech.ssml(text, select_voice())
    |> Azure.CognitiveServices.TextToSpeech.to_speech_of_neural_voice()
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

  defp do_something_and_create_file(function_name) do
    path = Atom.to_string(function_name) <> ".wav"

    apply(__MODULE__, function_name, [])
    |> (&File.write(path, &1)).()

    path
  end
end
