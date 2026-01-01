# Mindmeld Devops Take-home Exercise

This exercise is intended to test your knowledge and expertise of devops
tooling and commonly-used AWS products.

In this repository you'll find two directories:

* `api/` -- a simple key-value store API written in Rust
* `app/` -- a simple React frontend to interact with the KV store in a browser

The goal of the exercise is to operate a fully-functioning application stack on
AWS. Availability and resiliency are important, though your implementation does
not need to be overly elaborate. It is more important to demonstrate strong 
principles and opportunities for improvement than it is to build an exhaustive
solution. Be prepared to discuss potential improvements to your solution.

At minimum, you will need to:

* host the API
* host a Redis database for the API to communicate with
* host the frontend application and have it communicate with the API

You are free to choose whichever AWS products/services you believe will best
help you achieve the goal. We expect you to implement a solution using well-
known infrastructure as code tools, though which of those tools you use is
entirely up to you.

When you are finished with the exercise, please submit the configuration for
your solution and any documentation we might need in order to apply that
configuration.
