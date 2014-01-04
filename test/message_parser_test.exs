defmodule MessageParserTest do
  use ExUnit.Case, async: true

  import MessageParser

  setup_all do

    # Normal HTTP request message
    request_msg = """
    GET /user/update/ HTTP/1.1
    Accept: text/*
    Host: www.github.com
    Server: Host Ver
        service 1.0

    name=john&age=16
    """

    # Parsed result of request message
    parsed_request = [
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

    req_without_body = """
    GET /user/update/ HTTP/1.1
    Accept: text/*
    Host: www.github.com
    Server: Host Ver
        service 1.0

    """

    parsed_req_without_body = [
      method: "GET",
      path: "/user/update/",
      version: "HTTP/1.1",
      header: [
        Accept: "text/*",
        Host: "www.github.com",
        Server: "Host Ver\n    service 1.0"
      ],
      body: nil
    ]

    # Ordinary http response message
    response_msg = """
    HTTP/1.1 200 OK
    Content-length: 11
    Content-type: text/plain

    Hello world
    """

    parsed_response = [
      version: "HTTP/1.1",
      status_code: 200,
      reason: "OK",
      header: [
        "Content-length": "11",
        "Content-type": "text/plain"
      ],
      body: "Hello world"
    ]

    res_without_body = """
    HTTP/1.1 200 OK
    Content-length: 11
    Content-type: text/plain
    """

    parsed_res_without_body = [
      version: "HTTP/1.1",
      status_code: 200,
      reason: "OK",
      header: [
        "Content-length": "11",
        "Content-type": "text/plain"
      ],
      body: nil
    ]


    wrong_message = """
    Hello world
    bongbong
    Accept: text/*

    adfg

    """

    req_with_wrong_header = """
    PUT /user/john HTTP/1.1
    WrongHeader 

    Message
    """

    req_with_wrong_start = """
    PUT/user/johnHTTP/1.1
    Accepts: text/*

    Message
    """

    res_with_wrong_header = """
    HTTP/1.1 200 OK
    WrongHeader

    Wrong header 
    """

    res_with_wrong_start = """
    HTTP/1.1200OK
    Content-type: text/plain

    Wrong header 
    """


    shared_data = [
      request: request_msg,
      response: response_msg,
      parsed_request: parsed_request,
      parsed_response: parsed_response,
      wrong_message: wrong_message,
      req_with_wrong_header: req_with_wrong_header,
      req_with_wrong_start: req_with_wrong_start,
      res_with_wrong_header: res_with_wrong_header,
      res_with_wrong_start: res_with_wrong_start,
      req_without_body: req_without_body,
      parsed_req_without_body: parsed_req_without_body,
      res_without_body: res_without_body,
      parsed_res_without_body: parsed_res_without_body
    ]

    {:ok, shared_data}
  end

  test "parse_* only accepts binary and list messages" do
    assert_raise ArgumentError, "List or Binary expected", fn ->
      parse_request(:atom)
    end

    assert_raise ArgumentError, "List or Binary expected", fn ->
      parse_response(:atom)
    end
  end

  test "parse requset message with wrong start line would raise ArgumentError", shared_data do
    assert_raise ArgumentError, "Start line format error", fn ->
      parse_request(shared_data[:req_with_wrong_start])
    end
  end

  test "parse request message with wrong headers would raise ArgumentError", shared_data do
    assert_raise ArgumentError, "Headers format error", fn ->
      parse_request(shared_data[:req_with_wrong_header])
    end
  end

  test "parse response message with wrong start line would raise ArgumentError", shared_data do
    assert_raise ArgumentError, "Start line format error", fn ->
      parse_response(shared_data[:res_with_wrong_start])
    end
  end

  test "parse response msg with wrong headers would raise ArgumentError", shared_data do
    assert_raise ArgumentError, "Headers format error", fn ->
      parse_response(shared_data[:res_with_wrong_header])
    end
  end

  test "parse_* will return correct messages for correct binary", shared_data do
    assert(parse_request(shared_data[:request]) == shared_data[:parsed_request])
    assert(parse_request(shared_data[:req_without_body]) == shared_data[:parsed_req_without_body])
    assert(parse_response(shared_data[:response]) == shared_data[:parsed_response])
    assert(parse_response(shared_data[:res_without_body]) == shared_data[:parsed_res_without_body])
  end
end
