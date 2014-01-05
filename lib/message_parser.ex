defmodule MessageParser do

  @moduledoc """
  # MessageParser

  This module is used to parse HTTP messages, both request message and response message.

  The message format are as follows:

  ## Request message

      GET /user/update/ HTTP/1.1
      Accept: text/*
      Host: www.github.com
      Server: Host Ver
          service 1.0

      name=john&age=16

  ## Response message

      HTTP/1.1 200 OK
      Content-length: 11
      Content-type: text/plain

      Hello world

  The return value of parse_* functions would be a keyword list, such as:

  ## Parsed request message

      [
        method: "GET",
        path: "/user/update/",
        version: "HTTP/1.1",
        header: [
          Accept: "text/*",
          Host: "www.github.com",
          Server: "Host Ver\n    service 1.0"
        ],
        body: "name=john&age=16"
      ]

  ## Parsed response message

      [
        version: "HTTP/1.1",
        status_code: 200,
        reason: "OK",
        header: [
          "Content-length": "11",
          "Content-type": "text/plain"
        ],
        body: "Hello world"
      ]

  ## Examples

      parsed_request = MessageParser.parse_request(request_message)
      parsed_response = MessageParser.parse_response(response_message)
  """

  @type key :: atom
  @type value :: binary
  @type t :: [{key, value}] 

  @start_line_error "Start line format error"
  @headers_error "Headers format error"

  @doc """
  Parse HTTP request messages.

  ## Example 

      request = \"\"\"
        GET /user/update/ HTTP/1.1
        Accept: text/*
        Host: www.github.com
        Server: Host Ver
            service 1.0

        name=john&age=16
      \"\"\"

      MessageParser.parse_request(request)
  """
  @spec parse_request(binary) :: t
  def parse_request(msg) do
    parse_message msg, &parse_request_start_line/1
  end

  @doc """
  Parse HTTP response messages.

  ## Example

      response = \"\"\"
        HTTP/1.1 200 OK
        Content-length: 11
        Content-type: text/plain

        Hello world
      \"\"\"

      MessageParser.parse_response(response)
  """
  @spec parse_response(binary) :: t 
  def parse_response(msg) do
    parse_message msg, &parse_response_start_line/1
  end

  # Only binaries are accepted
  @spec parse_message(binary, (binary -> t)) :: t
  defp parse_message(msg, parser) do
    cond do
      is_binary(msg) ->
        parse_http_message msg, parser
      true ->
        raise(ArgumentError, message: "List or Binary expected")
    end
  end

  # Dispatch the different parts of messages to different parser functions.
  # Finally it concatenates the results and return the final result.
  @spec parse_http_message(binary, (binary -> t)) :: t
  defp parse_http_message(msg, start_line_parser) do
    { start_line_and_headers, message_body } = separate_message_body(msg)
    { start_line, headers } = separate_start_line_and_headers start_line_and_headers
    start_line_info = start_line_parser.(start_line)
    headers_info = parse_headers headers
    start_line_info ++ [header: headers_info] ++ [body: message_body]
  end

  # It separates the start line, headers and message body from the whole message.
  @spec separate_message_body(binary) :: {binary, binary}
  defp separate_message_body(msg) do
    case String.split(msg, "\n\n", global: false, trim: true) do
      [start_line_and_headers, message_body] ->
        { start_line_and_headers, String.rstrip(message_body) }
      [start_line_and_headers] ->
        { start_line_and_headers, nil }
    end
  end

  # It separates the start line and headers from the merged message
  @spec separate_start_line_and_headers(binary) :: {binary, binary}
  defp separate_start_line_and_headers(msg) do
    case String.split(msg, "\n", global: false) do
      [start_line, headers] ->
        { start_line, headers }
      _ ->
        raise(ArgumentError, message: "Message format error")
    end
  end

  # It parses the headers from the headers field and merges them to a keyword list.
  @spec parse_headers(binary) :: {binary, binary}
  defp parse_headers(headers) do
    header_list = String.split(headers, %r/\n(?=\w+)/)

    Enum.map header_list, fn (header) ->
      case String.split(header, %r/:\s?/) do
        [key, value] ->
          { binary_to_atom(key), String.rstrip(value) }
        _ ->
          raise(ArgumentError, message: @headers_error)
      end
    end
  end

  # It parses the start line of request message and merges the components into a keyword list 
  @spec parse_request_start_line(binary) :: t
  defp parse_request_start_line(start_line) do
    case String.split(start_line) do
      [method, path, version] ->
        [method: method, path: path, version: version]
      _ ->
        raise(ArgumentError, message: @start_line_error)
    end
  end

  # The same as parse_request_start_line but this is for start line of response message
  @spec parse_response_start_line(binary) :: t
  defp parse_response_start_line(start_line) do
    case String.split(start_line) do
      [version, status_code, reason] ->
        [version: version, status_code: binary_to_integer(status_code, 10), reason: reason]
      _ ->
        raise(ArgumentError, message: @start_line_error)
    end
  end
end