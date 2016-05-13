-- MySQL dump 10.13  Distrib 5.6.29, for Linux (x86_64)
--
-- Host: localhost    Database: gasky
-- ------------------------------------------------------
-- Server version	5.6.29

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `image` varchar(255) DEFAULT NULL,
  `image_dir` varchar(255) DEFAULT NULL,
  `entity_id` int(11) unsigned DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
INSERT INTO `images` VALUES (1,'e37e9dd0-912a-4222-8c79-4908e3d8d78f.jpg','0a66014a-187f-446f-b222-f3842343b0e9',1,'2016-04-14 23:04:13','2016-04-14 23:37:34');
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `legal_documents`
--

DROP TABLE IF EXISTS `legal_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `legal_documents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `body` text,
  `modified` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `legal_documents`
--

LOCK TABLES `legal_documents` WRITE;
/*!40000 ALTER TABLE `legal_documents` DISABLE KEYS */;
INSERT INTO `legal_documents` VALUES (1,'Privacy Policy','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\r\n\r\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?','2016-04-12 07:11:35'),(2,'Terms & Conditions','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\r\n\r\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?','2016-04-12 07:11:40');
/*!40000 ALTER TABLE `legal_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `managers`
--

DROP TABLE IF EXISTS `managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `managers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `managers`
--

LOCK TABLES `managers` WRITE;
/*!40000 ALTER TABLE `managers` DISABLE KEYS */;
INSERT INTO `managers` VALUES (17,'admin','$2y$10$7jjYnY1mNuwNYXbP24uz4.U0hAvItb15LViMZz.x.4MYtkLDQ34xu','admin@gasky.co','Dummy','admin','2016-05-13 01:26:00','2016-05-13 01:26:00');
/*!40000 ALTER TABLE `managers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_ratings`
--

DROP TABLE IF EXISTS `order_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_ratings` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `order_id` int(11) unsigned NOT NULL,
  `rating` int(1) NOT NULL,
  `details` enum('Late Delivery','Unprofessional Driver','Tank Wasn''t Full','Other') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_ratings`
--

LOCK TABLES `order_ratings` WRITE;
/*!40000 ALTER TABLE `order_ratings` DISABLE KEYS */;
INSERT INTO `order_ratings` VALUES (1,7,1,4,'Tank Wasn\'t Full','2016-04-14 20:15:53');
/*!40000 ALTER TABLE `order_ratings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `grade` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(10,6) NOT NULL,
  `longitude` decimal(10,6) NOT NULL,
  `details` text COLLATE utf8mb4_unicode_ci,
  `delivery_date` date NOT NULL,
  `delivery_time` int(2) unsigned NOT NULL,
  `received_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `delivering_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `finalized_at` datetime DEFAULT NULL,
  `payment_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `promo_id` int(11) unsigned DEFAULT NULL,
  `discount` decimal(8,2) NOT NULL DEFAULT '0.00',
  `total` decimal(8,2) DEFAULT NULL,
  `price_per_gallon` decimal(8,2) DEFAULT NULL,
  `gallons` decimal(9,3) DEFAULT NULL,
  `gas_total` decimal(8,2) DEFAULT NULL,
  `delivery_fee` decimal(8,2) DEFAULT NULL,
  `status` enum('in progress','cancelled','feedback','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'in progress',
  `paid` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,7,'regular','28-162 Bill Lucas Dr SE',33.736497,-84.386684,'Parking stall 74, third row inside.','2016-04-14',12,'2016-04-03 14:00:00','2016-04-14 19:14:15','2016-04-14 19:14:19','2016-04-14 23:37:34','2016-04-15 00:34:57','2016-04-14 20:15:53',19,5.00,33.82,2.79,12.123,33.82,5.00,'completed',1);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_methods` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `token` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
INSERT INTO `payment_methods` VALUES (34,15,'5c7bs2','2016-04-16 08:07:45','2016-04-16 08:07:45'),(35,15,'fk3ws2','2016-04-16 08:29:28','2016-04-16 08:29:28'),(36,7,'76234f',NULL,NULL);
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promo_usage`
--

DROP TABLE IF EXISTS `promo_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promo_usage` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `promo_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promo_usage`
--

LOCK TABLES `promo_usage` WRITE;
/*!40000 ALTER TABLE `promo_usage` DISABLE KEYS */;
/*!40000 ALTER TABLE `promo_usage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promos`
--

DROP TABLE IF EXISTS `promos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promos` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `percent_off` tinyint(3) NOT NULL,
  `dollar_amount_off` decimal(8,2) NOT NULL,
  `expires` datetime NOT NULL,
  `uses` int(11) NOT NULL DEFAULT '0',
  `max_uses` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promos`
--

LOCK TABLES `promos` WRITE;
/*!40000 ALTER TABLE `promos` DISABLE KEYS */;
INSERT INTO `promos` VALUES (19,'5bux',0,5.00,'2017-01-01 04:59:59',0,NULL,'2016-04-12 22:07:54'),(20,'10percent',10,0.00,'2015-01-01 04:59:59',0,NULL,'2016-04-12 22:08:23');
/*!40000 ALTER TABLE `promos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_areas`
--

DROP TABLE IF EXISTS `service_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_areas` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bounds` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_areas`
--

LOCK TABLES `service_areas` WRITE;
/*!40000 ALTER TABLE `service_areas` DISABLE KEYS */;
INSERT INTO `service_areas` VALUES (1,'30005','34.114608,-84.222995,34.088915,-84.261277,34.068674,-84.271817,34.071520,-84.251678,34.096598,-84.229474',NULL,'2016-04-15 22:10:26'),(3,'Downtown','33.755118,-84.403090,33.727503,-84.403698,33.729018,-84.358036,33.764545,-84.357530',NULL,NULL);
/*!40000 ALTER TABLE `service_areas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_pricing`
--

DROP TABLE IF EXISTS `service_pricing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_pricing` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cost` decimal(8,2) NOT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_pricing`
--

LOCK TABLES `service_pricing` WRITE;
/*!40000 ALTER TABLE `service_pricing` DISABLE KEYS */;
INSERT INTO `service_pricing` VALUES (1,'delivery',5.00,'2016-03-04 03:14:22'),(2,'cancellation',5.00,'2016-03-04 03:14:22'),(3,'regular',2.79,'2016-04-13 23:23:58');
/*!40000 ALTER TABLE `service_pricing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tokens`
--

DROP TABLE IF EXISTS `tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `selector` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `selector` (`selector`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tokens`
--

LOCK TABLES `tokens` WRITE;
/*!40000 ALTER TABLE `tokens` DISABLE KEYS */;
INSERT INTO `tokens` VALUES (12,4,'NDE1ZDJlYmRhZGM0NTRjNTE1MDQ5NWUw','7677eae533da70b50838b51f9065af0bed5f79bba7650886868bd9b007634b59'),(18,5,'YzAxZjA3M2ZlNTg1YmNhOTgzMDljODFk','979a785f6e85cdd95766a739495049a77ba08ca9e92c13255d2e1c59599d9243'),(19,6,'NTlmNGVkZmJmMTg4OTRlMjk0ODliNmNm','f764ed6c2f9c02b0656f1cef7ea5f04212f11b8441f111b657b07b78b04b34b0'),(23,7,'YzUxYWQwMGQxMWRmZjM1ZWYwZDkyNDIw','0fa7728038cb226916dc35049b223f53824c777ac8878c9fbe2f4f74064ea053'),(24,1,'OTNiZTNlY2JjZTRlZTBjNTcwZmYxMzhm','4f9162c2b1e42f7ebdf5be506d2ffa50e3954a3b4043c3cb76bb1b3630544679');
/*!40000 ALTER TABLE `tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_customer_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `photo` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `promo_id` int(10) unsigned DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'dressler3@gmail.com','$2y$10$QartBRts0V7zP2SIMEt8LOXnkCEcMYE38ZwuUJ7fSKxLtPrNYHrCK','Daniel Ressler','404.992.2589',NULL,'addae887952b2f760fb3c9a20af1a8a8.jpg',NULL,'2016-03-23 08:14:37','2016-03-31 15:32:48'),(3,'gloria.white07@yahoo.com','$2y$10$BcxDf5.LGbnNNB5gVIHqvOlvGz32EhgdNHX2d8cTHF/mq1EMfOjBm',NULL,NULL,NULL,NULL,NULL,'2016-03-29 12:01:29','2016-03-29 12:01:29'),(4,'banana.bonker.hannah@gmail.com','$2y$10$faMcA5hBglUB9pjexkCpGeEcrMOrFn57PQOjrom02Mez.mS4pg5ru','Hannah   Is Bonkerz','696.969.6969',NULL,'1c38bb12bbd4dea94c19a1f53b796fce.jpg',NULL,'2016-03-29 15:55:21','2016-03-30 06:01:24'),(5,'hressler13@gmail.com','$2y$10$5SVT.REcqazz2trzPWNJ2ukk0tW0SmBD9OAbDxcIAXSyKu0YNItEa',NULL,NULL,'15120810',NULL,NULL,'2016-03-31 15:24:26','2016-03-31 15:24:26'),(6,'rebekah.ressler01@gmail.com','$2y$10$9UNAFP7ssG/CXyIm9QcoDesq2ygW6D4taGAaKO0.qMC9znaQzOO3.',NULL,NULL,'16958005',NULL,NULL,'2016-03-31 15:26:04','2016-03-31 15:26:05'),(7,'eric@ericlorentz.com','$2y$10$xG6mw1RiOuMzQlhBouLokeib8Ys.IzVYcq4zLPRYO49HywiWiuNDG','Eric Lorentz','817.793.3372','34507238','a55030368a7316c52c37913f2b04a14c.jpg',19,'2016-03-31 16:04:59','2016-03-31 23:59:02'),(15,'hauntedcow@gmail.com','$2y$10$q1y7q4IY6.LcVPjy1TRV/uChql3zoj.5.EG3jfkRhny4SAH.nkgk.','Eric Lorentz',NULL,'89087748',NULL,NULL,'2016-04-16 01:29:06','2016-04-16 06:04:59');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicles`
--

DROP TABLE IF EXISTS `vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicles` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL,
  `plates` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `make` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `year` int(4) NOT NULL,
  `color` varchar(75) COLLATE utf8mb4_unicode_ci NOT NULL,
  `photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicles`
--

LOCK TABLES `vehicles` WRITE;
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
INSERT INTO `vehicles` VALUES (1,2,'BJZ123','Subaru','WRX',2012,'Red','2_1.jpg','2016-03-28 14:17:33','2016-03-28 14:58:45'),(2,1,'AAAAAA','Infiniti','FX 35',2006,'Grey','1_2.jpg','2016-03-29 11:29:52','2016-03-29 11:29:52'),(3,4,'FQK6491','Jeep','Patriot',2016,'Black','4_3.jpg','2016-03-29 20:08:58','2016-03-29 20:08:59'),(4,15,'BJZ123','Subaru','Impreza',2006,'Red','7_4.jpg','2016-03-31 23:57:13','2016-03-31 23:57:14');
/*!40000 ALTER TABLE `vehicles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-05-12 20:27:59
