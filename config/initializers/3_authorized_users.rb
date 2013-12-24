unless $PROGRAM_NAME.end_with?('rake')
  # Skip this initialization durring rake tasks
  # Heroku runs rake asset:precompile in sandbox mode with no ENV or DBs

  # Add the twitter ids for any users you want to authorize
  AuthorizedUsers.service.authorize({
    '14956791' => 'Arbind Thakur',
    '896339995' => 'Fae@food-truck.me',
  })
end