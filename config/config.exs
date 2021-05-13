import Config

config :honeko_pack, HonekoPack.Scheduler,
  jobs: [
    {"31 21 * * *", {HonekoPack, :run, []}},
    {"50 23 * * *", {HonekoPack, :run, []}},
    {"50 3 * * *", {HonekoPack, :run, []}}
  ]
