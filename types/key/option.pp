# Either `option` or `option="value"`
type Ssh::Key::Option = Pattern[/\A\w+(=".*")?\z/]
