-- phpMyAdmin SQL Dump
-- version 4.4.4
-- http://www.phpmyadmin.net
--
-- Host: 172.17.0.1:3306
-- Generation Time: May 18, 2015 at 08:38 AM
-- Server version: 5.6.24
-- PHP Version: 5.6.4-1+deb.sury.org~trusty+1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `dockermail`
--
CREATE DATABASE IF NOT EXISTS `dockermail` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `dockermail`;

-- --------------------------------------------------------

--
-- Table structure for table `installation`
--

CREATE TABLE IF NOT EXISTS `installation` (
  `software` enum('roundcube','owncloud','postfixadmin') NOT NULL,
  `done` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `installation`
--

INSERT INTO `installation` (`software`, `done`) VALUES
('roundcube', 0),
('owncloud', 0),
('postfixadmin', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `installation`
--
ALTER TABLE `installation`
  ADD PRIMARY KEY (`software`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
