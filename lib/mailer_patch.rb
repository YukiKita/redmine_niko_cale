# Niko-cale plugin for Redmine
# Copyright (C) 2010  Yuki Kita
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
require_dependency 'mailer'
 
module MailerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end
  end
  module InstanceMethods
    # Builds a tmail object used to email recipients of the added issue.
    #
    # Example:
    #   feeling_commented(comment) => tmail object
    #   Mailer.deliver_feeling_commented(comment) => sends an email to user of the feeling and the authors of commenters
    def feeling_commented(comment)
      feeling = Feeling.find(comment.commented)
      redmine_headers 'author' => comment.author, 'feeling_owner'=> feeling.user
      message_id comment
      recipients [feeling.user.mail]
      cc [comment.author.mail]
      subject "Re: [#{l(:label_niko_cale_feeling)} (#{feeling.user}@#{feeling.at})]"
      body :feeling => feeling, :comment=>comment
      render_multipart('feeling_commented', body)
    end
  end
end


