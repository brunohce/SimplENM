<img src="https://user-images.githubusercontent.com/52681915/117520421-7b0b2480-af7e-11eb-8456-9dd8280120f0.png" width="400" height="250">



**My script to run ENM using Maxent alghoritm!**

It is quite a simple script, nothing much sofisticated but it works :)

I've tried to comment the code as much as possible but you can write me if you have any doubts @didelphisaurita 

So, basically to run need a root folder with the following structure

<details><summary>Structure:</summary>
    <pre>

```console

├── Data
│   ├── elev
│   │   └── elevation.tif
│   ├── masks
│   │   ├── calibration_area_shape.dbf
│   │   ├── calibration_area_shape.dbf
│   │   ├── calibration_area_shape.prj
│   │   ├── calibration_area_shape.shp
│   │   ├── calibration_area_shape.shx
│   ├── raster
│   │   ├── current
│   │   │   ├── BIO01.tif
│   │   ├── RCP26
│   │   │   ├── BIO01.tif
│   │   ├── RCP45
│   │   │   ├── BIO01.tif
│   │   ├── RCP60
│   │   │   ├── BIO01.tif
│   │   └── RCP85
│   │   │   ├── BIO01.tif
│   └── records
│       ├── records_lhq
│       │   ├── Records Akodon cursor.csv
│       │   ├── Records Akodon montensis.csv

```
 </pre>
   </details>
   
Elevation and mask are optional
    1)  If you don't want to extract elevation, you can remove/comment the part of the script that computes elevation or just run it anyway, you'll get an error message but everything else should work just fine.
    2)  

