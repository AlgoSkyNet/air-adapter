rem PATH needs to include AIR SDK so asdoc is accessible

asdoc -source-path src -doc-sources src -output doc -library-path+=C:\Users\wenjun\Documents\Project\air-adapter\lib  +configname=air -exclude-sources src\tests -main-title "OpenFin Air Adapter API Documentation" -footer "<a href='https://openfin.co' target='_blank'>https://openfin.co</a>"
