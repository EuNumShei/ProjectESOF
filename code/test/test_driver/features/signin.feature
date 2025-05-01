Feature: Sign In
	The user should be able to sign in

Scenario Outline: Sign in
   Given: I'm in the Sign In page
   When: I insert my <email>
   And: I write a <password>
   And: I select my <status> (cook or client)
   And:  I tap the sign in button
   Then: My account is created

Examples:
   | email               |  password  | status   |
   | "gui13@gmail.com"   | "1234jgs"  | "client" |
   | "juju74@hotmail.com"| "cjhwvf4y" | "client" |
   | "sofs23@gmail.com"  | "d834g5i"  | "cook"   |