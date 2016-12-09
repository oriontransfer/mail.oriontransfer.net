# mail.oriontransfer.net

This is the Orion Transfer mail server management interface.

## Motivation

Hosting and billing customers for private email services.

## Installation

Create an appropriate user for accessing the database:

```sql
CREATE USER IF NOT EXISTS 'http'@'localhost';
GRANT ALL PRIVILEGES ON vmail.* TO 'http'@'localhost';
FLUSH PRIVILEGES;
```

Setup `sudo` for computing disk usage, e.g. in `/etc/sudoers.d/http`:

```sudoers
http  ALL=(ALL) NOPASSWD: /usr/bin/du
```

### Dovecot Setup

You'll want to configure Dovecot to interface with MySQL:

#### `/etc/dovecot/dovecot.conf`

	auth_mechanisms = plain login
	mail_location = mdbox:~/mail.mdbox
	mail_uid = vmail
	mail_gid = vmail
	
	passdb {
		driver = sql
		args = /etc/dovecot/dovecot-sql.conf
	}
	
	protocols = imap
	
	service imap-login {
		client_limit = 512
		inet_listener imap {
		port = 0
		}
		process_limit = 8
		service_count = 0
		vsz_limit = 128 M
	}
	
	ssl_cert = </etc/ssl/private/mail.oriontransfer.net.pem
	ssl_key = </etc/ssl/private/mail.oriontransfer.net.key
	
	userdb {
		driver = sql
		args = /etc/dovecot/dovecot-sql.conf
	}
	
	verbose_proctitle = yes
	
	service auth {
		unix_listener /var/spool/postfix/private/auth {
			mode = 0660
			# Assuming the default Postfix user and group
			user = postfix
			group = postfix
		}
	}
	
	protocol lda {
		mail_plugins = $mail_plugins sieve
	}
	
	plugin {
		zlib_save = xz
		zlib_save_level = 4
	}

	# Enable zlib plugin globally for reading/writing:
	mail_plugins = $mail_plugins zlib

	namespace {
		separator = /
		inbox = yes
	}

#### `/etc/dovecot/dovecot-sql.conf`

	driver = mysql

	connect = host=localhost dbname=vmail user=vmail password=foobar

	password_query = SELECT password FROM accounts LEFT JOIN domains ON accounts.domain_id = domains.id WHERE accounts.local_part = '%n' AND domains.name = '%d' AND domains.is_enabled = 1 AND accounts.is_enabled = 1

	user_query = SELECT mail_location AS mail, concat('/srv/mail/', domains.name, '/', accounts.local_part) AS home, 'vmail' AS uid, 'vmail' AS gid FROM accounts LEFT JOIN domains ON accounts.domain_id = domains.id WHERE accounts.local_part = '%n' AND domains.name = '%d' AND domains.is_enabled = 1 AND accounts.is_enabled = 1

	# For using doveadm -A:
	iterate_query = SELECT concat(accounts.local_part, '@', domains.name) AS username FROM accounts LEFT JOIN domains ON accounts.domain_id = domains.id WHERE domains.is_enabled = 1 AND accounts.is_enabled = 1

### Postfix Setup

Postfix talks to Dovecot for authentication and virtual mailbox lookup:

#### `/etc/postfix/master.cf`

Talk to Dovecot for auth:

	smtpd_sasl_type = dovecot
	smtpd_sasl_path = /var/spool/postfix/private/auth
	smtpd_sasl_auth_enable = yes
	smtpd_use_tls=yes
	smtpd_tls_auth_only=yes
	smtpd_tls_cert_file=/etc/ssl/private/mail.oriontransfer.net.pem
	smtpd_tls_key_file=/etc/ssl/private/mail.oriontransfer.net.key
	smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache
	smtpd_tls_session_cache_timeout = 3600s

#### `/etc/postfix/main.cf`

Use dovecot for local delivery, filter it via spamc.

	dovecot   unix  -       n       n       -       -       pipe
	  flags=DRhu user=vmail:vmail argv=/usr/bin/vendor_perl/spamc -f -u spamd -e /usr/lib/dovecot/deliver -f ${sender} -d ${user}@${nexthop}

#### `/etc/postfix/virtual_mailbox_maps.cf`

	user = vmail
	password = foobar
	dbname = vmail
	query = SELECT 1 FROM accounts LEFT JOIN domains ON accounts.domain_id = domains.id WHERE accounts.local_part = '%u' AND domains.name = '%d' AND domains.is_enabled = 1

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2016, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
