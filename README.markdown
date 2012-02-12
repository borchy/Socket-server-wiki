# Socket server wiki

This is my first shot at creating a web application.
It is a minimalistic wiki software.
The socket server is my own as part of the learning experience.

## How to use:
Simply start the server.rb file with a ruby interpter (version 1.9.1 at least). Pass two parameters, the first is the host and the second is the port you wish to run the server on.
 
## Wiki specification:
Type the name of the page you are looking for in the address bar 

* if the page exists, the server will show you its contents
* if it doesn't, the server will load a page creation form, which on submiting will create the page and you will be redirected to it 
* If you want to edit a page enter the name of the page followed by "/edit"
* if the page exists, the server will load the edit page form, filled with the contents of the page 
* upon submiting the form, you will be redirected to the new page 
* if the page doesn't exist, you will be redirected to the create page form

## Formatting:
For now the only available formatting is the carriage return.
Which means that while in the create/edit page form when the user enters a new line
it will be saved as a new line. Under the hood, the new line symbol
is converted to the <br> tag in HTML.
