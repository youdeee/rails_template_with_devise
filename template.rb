append_file ".gitignore", <<-CODE

.DS_Store
/coverage/
/spec/reports/
/spec/examples.txt
/vendor/bundle
CODE

route "root to: 'home#index'"

file "app/controllers/home_controller.rb", <<-CODE
class HomeController < ApplicationController
end
CODE

file "app/views/home/index.html.erb", <<-CODE
<div class="position-relative overflow-hidden p-3 p-md-5 m-md-3 text-center bg-light">
  <div class="col-md-5 p-lg-5 mx-auto my-5">
    <h1 class="font-weight-normal"><%= t(".description") %></h1>
    <p class="lead font-weight-normal"><%= t(".subdescription") %></p>
    <%= link_to t(".create_account"), "", class: "btn btn-outline-secondary" %>
  </div>
  <div class="product-device shadow-sm d-none d-md-block"></div>
  <div class="product-device product-device-2 shadow-sm d-none d-md-block"></div>
</div>
<style>
  .product-device {
    position: absolute;
    right: 10%;
    bottom: -30%;
    width: 300px;
    height: 540px;
    background-color: #333;
    border-radius: 21px;
    -webkit-transform: rotate(30deg);
    transform: rotate(30deg);
  }

  .product-device::before {
    position: absolute;
    top: 10%;
    right: 10px;
    bottom: 10%;
    left: 10px;
    content: "";
    background-color: rgba(255, 255, 255, .1);
    border-radius: 5px;
  }

  .product-device-2 {
    top: -25%;
    right: auto;
    bottom: 0;
    left: 5%;
    background-color: #e5e5e5;
  }

  .overflow-hidden { overflow: hidden; }
</style>
CODE

file("public/404.html", <<-CODE, force: true)
<!DOCTYPE html>
<html>
  <head>
    <title>Page not found (404)</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
  </head>
  <body>
    <h1>Page not found (404)</h1>
  </body>
</html>
CODE

file("public/422.html", <<-CODE, force: true)
<!DOCTYPE html>
<html>
  <head>
    <title>Change was rejected (422)</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
  </head>
  <body>
    <h1>Change was rejected (422)</h1>
  </body>
</html>
CODE

file("public/500.html", <<-CODE, force: true)
<!DOCTYPE html>
<html>
  <head>
    <title>Internal server error (500)</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
  </head>
  <body>
    <h1>Internal server error (500)</h1>
  </body>
</html>
CODE
