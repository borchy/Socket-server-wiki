# Socket server wiki

This is my first shot at creating a web application.
It is a minimalistic wiki software.
The socket server is my own as part of the learning experience.
I have also provided a logger client to track all server requests/responses.

## How to use
Simply start the server.rb file with a ruby interpter (version 1.9.1 at least). Pass two parameters, the first is the host and the second is the port you wish to run the server on.
 
## Wiki specification
Type the name of the page you are looking for in the address bar 

* if the page exists, the server will show you its contents
* if it doesn't, the server will load a page creation form, which on submiting will create the page and you will be redirected to it 
* If you want to edit a page enter the name of the page followed by "/edit"
* if the page exists, the server will load the edit page form, filled with the contents of the page 
* upon submiting the form, you will be redirected to the new page 
* if the page doesn't exist, you will be redirected to the create page form
* every other action will result in loading the error page

## Formatting
I have implemented part of the markdown language. 
For now it supports paragraphs, headers (from 1 to 4), links (still a bug there), lists (ordered and unordered), quotes and code. The only text styles for now are bold and italic which don't actually adhere to the Markdown specification. The difference in my implementation is that the italics tag is created by using "_" on both sides of the phrase.

## Logger client
I have provided two files. One written in C and the other in Ruby.
The tasks they perform are identical.
All the client does is to connect to the server on the same host and port,
and print in the standard output every server request and its respective response.
To connect to the server simply start the client script with the host and port arguments.