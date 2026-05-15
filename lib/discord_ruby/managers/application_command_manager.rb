module DiscordRuby
  module Managers
    class ApplicationCommandManager < BaseManager
      attr_reader :guild_id

      def initialize(bot, guild_id = nil)
        super(bot)
        @guild_id = guild_id
      end

      def fetch_all
        if @guild_id
          @bot.api.get_guild_application_commands(@bot.application_id, @guild_id)
        else
          @bot.api.get_global_application_commands(@bot.application_id)
        end
      end

      def fetch(id)
        if @guild_id
          @bot.api.get_guild_application_command(@bot.application_id, @guild_id, id)
        else
          @bot.api.get_global_application_command(@bot.application_id, id)
        end
      end

      def create(**options)
        if @guild_id
          @bot.api.create_guild_application_command(@bot.application_id, @guild_id, **options)
        else
          @bot.api.create_global_application_command(@bot.application_id, **options)
        end
      end

      def edit(id, **options)
        if @guild_id
          @bot.api.modify_guild_application_command(@bot.application_id, @guild_id, id, **options)
        else
          @bot.api.modify_global_application_command(@bot.application_id, id, **options)
        end
      end

      def delete(id)
        if @guild_id
          @bot.api.delete_guild_application_command(@bot.application_id, @guild_id, id)
        else
          @bot.api.delete_global_application_command(@bot.application_id, id)
        end
      end

      def bulk_overwrite(commands)
        if @guild_id
          @bot.api.bulk_overwrite_guild_application_commands(@bot.application_id, @guild_id, commands)
        else
          @bot.api.bulk_overwrite_global_application_commands(@bot.application_id, commands)
        end
      end

      def fetch_permissions(command_id = nil)
        return nil unless @guild_id
        if command_id
          @bot.api.get_guild_application_command_permissions(@bot.application_id, @guild_id, command_id)
        else
          @bot.api.get_guild_application_commands_permissions(@bot.application_id, @guild_id)
        end
      end
    end
  end
end
