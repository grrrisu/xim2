# Xim2.Umbrella

### Develope

#### Setup

cd `apps/xim2_web/assets` and `npm install`
back to root path `mix phx.server`

### New Sub Application

go to `./apps`and issue the mix new command like this:
`mix new biotope --module Biotope --sup`

### Observer

```
Mix.ensure_application!(:wx)
Mix.ensure_application!(:runtime_tools)
Mix.ensure_application!(:observer)
:observer.start
```
