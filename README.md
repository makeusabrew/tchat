# tchat

Terminal based, hassle free chat.

## Installation

```sudo npm install -g tchat```

## Usage

```tchat``` - connects to the tchat server and creates a new randomly named room:

```
nick@dev:~$ tchat
Connecting as makeusabrew
Created new room: "rechargeable"
=> hello world!
```

```tchat [room]``` - connects to the tchat server and joins the named room. Note
that the room must already exist; at present the only way to create a room is
to let the server randomly assign you one which can then be shared with other
participants.

```
nick@dev:~$ tchat rechargeable
Connecting as makeusabrew
Joined room: "rechargeable"
=> 
```

Once launched, CTRL+C exits.

## License

(The MIT License)

Copyright (C) 2013 by Nick Payne <nick@kurai.co.uk>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE
