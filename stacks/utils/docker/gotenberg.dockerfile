FROM docker.io/gotenberg/gotenberg:8.37

# The gotenberg chromium route is used to convert .eml files. We do not
# want to allow external content like tracking pixels or even javascript.
CMD [ "gotenberg", "--chromium-disable-javascript=true", "--chromium-allow-list=file:///tmp/.*" ]
