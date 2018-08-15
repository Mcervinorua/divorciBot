require 'faraday'

class MyBot
  def self.token=(string); @token=string end
  def self.token; @token end

  def initialize(dialogues)
    @dialogue = dialogues
  end

  def new_message(params)
    chat_id = params["message"]["chat"]["id"]
    received_message = params["message"]["text"]

    dialogue = @dialogue.find {|e| e["id"] == received_message}
    message = dialogue["text"]
    body = {
      chat_id: chat_id,
      text: message}
    if dialogue["options"].nil?
      body[:reply_markup] = {remove_keyboard: true}.to_json
    else
      body[:reply_markup] = { keyboard: [dialogue["options"]]}.to_json
    end

    send_message(body)
  end

  private

  def send_message(body)
    if MyBot.token.nil?
      p "Intercepted message with payload: #{body}"
    else
      conn = Faraday.new(:url => 'https://api.telegram.org/')
      conn.post("/bot#{MyBot.token}/sendMessage", body)
    end
  end
end
