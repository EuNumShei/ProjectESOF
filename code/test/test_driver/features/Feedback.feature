Feature: Give Feedback
    The user should be able to give feedback about a give meal that had at a restaurant.

Scenario Outline: Give feedback
    Given: I'm in the Home screen
    When: I tap the  rightmost button on the bottom bar (the one with a question mark)
    And: I tap either Thumbs Up or Thumbs Down button
    And: Optionally write a <review> about the meal
    And: Tap the submit button
    Then: The feedback is submitted

Examples:
    | review                                                    |  
    | "I liked everything about my meal"                        |
    | "I was a big fan of the rice, but no so much of the meat" |
    | "I disliked everything, terrible meal"                    |