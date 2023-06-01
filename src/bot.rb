MAGIC_WORD = 'tacos'

module Bot
  def self.handle_message(client, received_message)
    if message = received_message["message"]
      channel_id = message["channelId"]

      if message["type"] == "new_message"
        if message["text"].downcase == "hello bot"
          client.perform('send_message', {
            text: "Hello, @#{message.dig("author", "username")}!",
            channelId: channel_id
          })
        end

        if message["text"].match?(/#{MAGIC_WORD}/)
          client.perform('send_message', {
            text: "You said #{message.dig("streamer", "username")}'s magic word!",
            channelId: channel_id
          })
        end
      end
    end
  end
end
