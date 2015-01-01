# docker-sonarr (Formally known as NzbDrone)
This is a [sonarr/NzbDrone](https://sonarr.tv/) docker container.

__Note__: As of yet, I haven't managed to get the https:// aspect working.  If you check out the Dockerfile you'll see i'm installing pvk (to generate pvk's on linux), and then in cookbooks/sonarr/recipes/default.rb you'll see where i'm generating the pvk, and importing in mono.

From there i'm using monos httpcfg tool to get the thumbprint and import it into the sonarr config.

That all seems to be fine, however hitting https:// still doesn't work, http:// is fine though.

## Use
The easiest way to use this is probably a fig file:
```
sonarr:
  image: stono/sonarr 
  environment:
    - sonarr_api_key=your-own-key // One will be generated if this isn't set
    - sonarr_username=sonarr // Defaults to sonarr
    - sonarr_password=password // One will be generated if this isn't set
  volumes:
    - ./storage:/storage
  ports:
    - "8989:8989"
    - "9898:9898"
```
From there you can start it with `sudo fig up -d` and connect to it on:
  - http://127.0.0.1:8989
  - https://127.0.0.1:9898

Or if you don't want to use fig, this will do the job:
```
sudo docker run -d && \
  -v "/path/to/your/storage:/storage" && \
  -e="sonarr_api_key=your-own-key" && \
  -e="sonarr_username=sonarr" && \
  -e="sonarr_password=password" && \
  -p "8989:8989" && \
  -p "9898:9898" stono/sonarr
```

## Storage
All config / data gets written to /storage/nzbdrone on the first "fig up", so if you mount in that volume to somewhere on your system, all your configuration will be preserved through docker container updates.

You could mount in your own, already existing config directory if you like.
