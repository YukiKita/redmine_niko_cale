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

class FeelingsMailer < Mailer
  # Builds a Mail::Message object used to email to author of feeling
  #
  # Example:
  #   feeling_commented(comment) => Mail::Message object
  def feeling_commented(comment)
    @feeling = Feeling.find(comment.commented.id)
    author = comment.author
    owner = @feeling.user
    @comment = comment
    @feeling_url = url_for(controller: 'feelings', action: 'show', id: @feeling)
    redmine_headers 'author' => author, 'feeling_owner' => owner
    message_id comment
    recipients = [owner.mail]
    language = owner.language.blank? ? Setting.default_language : owner.language
    subject = "Re: [#{Setting.app_title}]#{ll(language, :label_niko_cale_feeling)} (#{owner}@#{@feeling.at})"
    cc = [author.mail]
    mail to: recipients, cc: cc, subject: subject
  end
end

