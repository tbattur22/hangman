## Demo Project to implement Hangman game

### Dictionary and Hangman components are implemented as independent elixir services (applications) and two separate clients (text and browser) have been implemented expose the Hangman game to end users.

### The language and technologies used:
- Elixir 1.8.4/OTP 27
- Phoenix 1.7.21/LiveView
- Html/JavaScript/TailwindCSS

### How to run locally
#### Browser client via Phoenix
- Clone the repo
- cd b2
- mix deps.get
- mix phx.server

#### Text Client via iex repl
- Clone the repo
- Open two terminal tabs locally
- In 1st tab cd hangaman
- iex --sname hangman@localhost -S mix (start the hangman server)
- In 2nd tab cd text_client
- iex --sname c1 -S mix
- TextClient.start()
