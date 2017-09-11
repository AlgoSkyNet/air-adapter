# air-adapter
## Build the project

1. Dependencies
    lib/OpenFinAirNativeExtension-6.0.1.ane
    lib/websocket.swc

2. Air compiler config
    Target Platform: Desktop pure Actionscript
    Output Type: Library
    Output filename: OpenFinAirAdapter-x.y.z.swc

3. Generate API Docs
    createAPIDocs.bat create API docs in doc/

4. Update docs on s3

    ```
    aws s3 cp doc  s3://public.openfin.co/test/doc/6.0.2  --cache-control max-age=60 --recursive
    ```

5. Update swc on s3
    update OpenFinAirAdapter-x.x.x.swc to cdn.openfin/release/adapter/air
    copy OpenFinAirAdapter-x.x.x.swc to openfinAirAdapter.swc
    update openfinAirAdapter.swc to cdn.openfin/release/adapter/air

6. Update versions page
    create x.x.x.md and upload to cdn.openfin.co/release/meta/air-adapter
    update cdn.openfin.co/release/meta/air-adapter/versions


@todo: mavenize with flexmojos
