# Xs-merchant

## Configuration

Set the API base URL using `--dart-define` (overrides `.env` and fallback):

```bash
flutter run --dart-define=BASE_URL=https://your-api.example.com
```

Features:

 - Orders history and Verification Page with working search and delivering order works(Rfid yet to find)

1. Deliver Item with rfid(Yet to find) UI:

![alt text](docs-image/image-19.png)

 - When Rfid Number(now its orderid) is entered:

 ![alt text](docs-image/image-20.png)

2. Orders Page with timed counts

![alt text](docs-image/image-11.png)

- Whole New Orders Page which shows the orders received with time of delivery (7:00 am, 11:15 am, 12:00 pm, 3:00 pm).

![alt text](docs-image/image-21.png)

3. Orders Delivered History and Verfication Page
 - Note: It only shows delivered orders but we can search not delivered orders 

![alt text](docs-image/image-13.png)

 - Searching Order id 8:

 ![alt text](docs-image/image-14.png)

 - Click Enter or click button tick to get item

 ![alt text](docs-image/image-15.png)

  - Click Reload on search bar to get default page

  ![alt text](docs-image/image-16.png)


4. Sort:

 - Sort by Name by default:

![alt text](docs-image/image-9.png)

 - Sort by Price:
 
![alt text](docs-image/image-10.png)

 - Sort by Low_Stocks:

![alt text](docs-image/image-18.png)

 - Sort Toggle in Not on Menu too, for easy access

![alt text](docs-image/image-12.png)

5. Modify Item in Bulk with Name Checkpoint

![alt text](docs-image/image-8.png)

6. Single Modify Items for Changing the both Name and Price

![alt text](docs-image/image-5.png)

 - When Changed

![alt text](docs-image/image-4.png)

7. Added Reconfirmation for Easy Adding and removing items from Menu
 - On Menu to Off Menu

![alt text](docs-image/image-2.png)

 - Off Menu to On menu

 ![alt text](docs-image/image-3.png)

8. Add New item rework with checkpoint

![alt text](docs-image/image-7.png)

- When Changed

![alt text](docs-image/image-6.png)

9. Added Delete Item Feature:

![alt text](docs-image/image-1.png)
