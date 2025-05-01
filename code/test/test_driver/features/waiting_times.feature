Feature: Waiting times
	The users should be able to know the waiting times for a restaurant

Scenario Outline: See the waiting times for the restaurant
    Given: I'm in the Home Page
    When: I tap the Clock button 
    Then: I can see the aproximate waiting time and a suggestion based on the waiting time and prices of the restaurant