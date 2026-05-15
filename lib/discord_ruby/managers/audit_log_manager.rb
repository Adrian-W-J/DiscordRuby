module DiscordRuby
  module Managers
    class AuditLogManager < BaseManager
      def fetch(guild_id, **options)
        data = @bot.api.get_guild_audit_log(guild_id, **options)
        data['audit_log_entries'].map { |entry| AuditLogEntry.new(@bot, entry) }
      end
    end
  end
end
