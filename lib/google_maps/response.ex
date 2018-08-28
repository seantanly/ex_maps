defmodule GoogleMaps.Response do
  @moduledoc false

  @type t :: {:ok, map()} | {:error, error()} | {:error, error(), String.t()}

  @type status :: String.t()

  @type error :: HTTPoison.Error.t() | status()

  def wrap({:error, error}), do: {:error, error}

  def wrap({:ok, %{body: body} = response}) when is_binary(body) do
    binary = IO.iodata_to_binary(body)

    decoded_body =
      Jason.decode(body, strings: :copy)
      |> case do
        {:ok, body} ->
          body

        {:error, error} ->
          IO.puts("[#{__MODULE__}]: #{inspect(error)}\n#{inspect(body)}")
          IO.puts(binary)
          Poison.decode!(body)
      end

    wrap({:ok, %{response | body: decoded_body}})
  end

  def wrap({:ok, %{body: %{"status" => "OK"} = body}}), do: {:ok, body}

  def wrap({:ok, %{body: %{"status" => status, "error_message" => error_message}}}),
    do: {:error, status, error_message}

  def wrap({:ok, %{body: %{"status" => status}}}), do: {:error, status}
end
