import Config

config :honeko_pack, HonekoPack.Scheduler,
  jobs: [
    {"30 21 * * *", {HonekoPack, :run, []}}
  ]
