Feature: Log In 
	The user should be able log in

Scenario Outline: Log In 
    Given: I'm in the Log In page
    When: I write the <email> I'm registered with in the app
    And: I write the <password> I chose when signing in
    And: I tap the Log In button
    Then: I'm logged in the app

Examples:
    | email              | password      |
    | "up202204876@up.pt"| "Gui#13052004"|
    | "up202207976@up.pt"| "123julio"    |
    | "up20202020@up.pt" | "Sofja@0777"  |