SpreeXero
=========

Spree integration to Xero (http://www.xero.com/)

*  call order.submit_invoice_to_xero to create order invoice on Xero
*  call payment.submit_payment_to_xero to create payment on Xero

Implementation
=============

* include spree_xero in gem file
* do "sudo bundle install"
* do "rake db:migrate"
* generate private and public keys. For help, read about "Using OpenSSL" on http://blog.xero.com/developer/api-overview/setup-an-application/
* login to https://api.xero.com and add your private application, upload public key file. When you finish, you'll get consumer key and secret
* on your spree app, go to Admin-Configuration-XeroSettings, enter your consumer key, secret and upload your private key file


Copyright (c) 2011 [name of extension creator], released under the New BSD License
