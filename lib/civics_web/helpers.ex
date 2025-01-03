defmodule CivicsWeb.Helpers do
  @number_comma_regex ~r/\B(?=(\d{3})+(?!\d))/
  def format_dollars(number) do
    Regex.replace(@number_comma_regex, "#{number}", ",")
  end

  def format_float(number) do
    :erlang.float_to_binary(number, decimals: 2)
  end
end
