# MessageParser

A HTTP message parser that written in Elixir.

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

The return value of parse_*_message function would be a keyword list, such as:

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
"""This module is used to parse HTTP messages, both request message and response message.

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

The return value of parse_*_message function would be a keyword list, such as:

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

License: MIT v2