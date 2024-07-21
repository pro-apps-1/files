-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 21, 2024 at 06:40 PM
-- Server version: 10.6.18-MariaDB-0ubuntu0.22.04.1
-- PHP Version: 8.1.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rocket_ssh_cp`
--

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_categories`
--

CREATE TABLE `rs_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `protocol` varchar(50) NOT NULL,
  `cid` int(11) NOT NULL,
  `ctime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_conn_logs`
--

CREATE TABLE `rs_conn_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `server_id` int(11) NOT NULL,
  `login_time` int(11) NOT NULL,
  `logout_time` int(11) NOT NULL,
  `pid` varchar(30) NOT NULL,
  `vpn_protocol` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_credits`
--

CREATE TABLE `rs_credits` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `operation` varchar(50) NOT NULL,
  `amount` float NOT NULL,
  `desc` varchar(512) NOT NULL,
  `cid` int(11) NOT NULL,
  `ctime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_domains`
--

CREATE TABLE `rs_domains` (
  `id` int(11) NOT NULL,
  `subdomain` varchar(255) NOT NULL,
  `category_id` int(11) NOT NULL,
  `zone_id` varchar(255) NOT NULL,
  `ctime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_migrations`
--

CREATE TABLE `rs_migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_packages`
--

CREATE TABLE `rs_packages` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `validity_days` int(11) NOT NULL,
  `start_time_type` varchar(50) NOT NULL,
  `limit_users` int(11) NOT NULL,
  `price` float NOT NULL,
  `traffic` int(11) NOT NULL,
  `is_disabled` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_servers`
--

CREATE TABLE `rs_servers` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `ssh_user` varchar(255) NOT NULL,
  `ssh_pass` varchar(255) NOT NULL,
  `ssh_port` int(11) NOT NULL,
  `country_code` varchar(20) NOT NULL,
  `category_id` int(11) NOT NULL,
  `limit_online_users` varchar(30) NOT NULL,
  `is_disabled` tinyint(1) NOT NULL,
  `is_configured` tinyint(1) NOT NULL,
  `ctime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_servers_meta`
--

CREATE TABLE `rs_servers_meta` (
  `id` int(11) NOT NULL,
  `server_id` int(11) NOT NULL,
  `meta_name` varchar(255) NOT NULL,
  `meta_value` text NOT NULL,
  `ctime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_settings`
--

CREATE TABLE `rs_settings` (
  `id` int(11) NOT NULL,
  `name` varchar(512) NOT NULL,
  `value` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_sys_logs`
--

CREATE TABLE `rs_sys_logs` (
  `id` int(11) NOT NULL,
  `log_type` varchar(255) NOT NULL,
  `log_desc` varchar(512) NOT NULL,
  `cid` int(11) NOT NULL,
  `ctime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_users`
--

CREATE TABLE `rs_users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `mobile` varchar(11) NOT NULL,
  `role` varchar(50) NOT NULL COMMENT 'admin,reseller,subscriber',
  `credit` float NOT NULL,
  `unlimited` tinyint(1) NOT NULL,
  `status` varchar(50) NOT NULL,
  `status_desc` varchar(255) NOT NULL,
  `desc` varchar(512) NOT NULL,
  `cid` int(11) NOT NULL,
  `ctime` int(11) NOT NULL,
  `uid` int(11) NOT NULL,
  `utime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_users_meta`
--

CREATE TABLE `rs_users_meta` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `meta_key` varchar(255) NOT NULL,
  `meta_value` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_users_online`
--

CREATE TABLE `rs_users_online` (
  `id` int(11) NOT NULL,
  `server_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_ip` varchar(100) NOT NULL,
  `session_key` varchar(100) NOT NULL,
  `pid` varchar(30) NOT NULL,
  `vpn_protocol` varchar(100) NOT NULL,
  `ctime` int(11) NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_users_packages`
--

CREATE TABLE `rs_users_packages` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `cid` int(11) NOT NULL,
  `ctime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_users_subs`
--

CREATE TABLE `rs_users_subs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `package_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `start_time` int(11) NOT NULL,
  `end_time` int(11) NOT NULL,
  `token` varchar(100) NOT NULL,
  `limit_users` int(11) NOT NULL,
  `validity_days` int(11) NOT NULL,
  `traffic` int(11) NOT NULL,
  `price` float NOT NULL,
  `uuid` varchar(512) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rs_users_traffics`
--

CREATE TABLE `rs_users_traffics` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `download` float NOT NULL,
  `upload` float NOT NULL,
  `total` float NOT NULL,
  `ctime` int(11) NOT NULL,
  `utime` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rs_categories`
--
ALTER TABLE `rs_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rs_conn_logs`
--
ALTER TABLE `rs_conn_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `rs_credits`
--
ALTER TABLE `rs_credits`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `rs_domains`
--
ALTER TABLE `rs_domains`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rs_migrations`
--
ALTER TABLE `rs_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rs_packages`
--
ALTER TABLE `rs_packages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rs_servers`
--
ALTER TABLE `rs_servers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ip` (`ip`);

--
-- Indexes for table `rs_servers_meta`
--
ALTER TABLE `rs_servers_meta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `server_id` (`server_id`);

--
-- Indexes for table `rs_settings`
--
ALTER TABLE `rs_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rs_sys_logs`
--
ALTER TABLE `rs_sys_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `rs_users`
--
ALTER TABLE `rs_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `rs_users_meta`
--
ALTER TABLE `rs_users_meta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`user_id`);

--
-- Indexes for table `rs_users_online`
--
ALTER TABLE `rs_users_online`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `server_id` (`server_id`);

--
-- Indexes for table `rs_users_packages`
--
ALTER TABLE `rs_users_packages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `package_id` (`package_id`);

--
-- Indexes for table `rs_users_subs`
--
ALTER TABLE `rs_users_subs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `package_id` (`package_id`);

--
-- Indexes for table `rs_users_traffics`
--
ALTER TABLE `rs_users_traffics`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_categories`
--
ALTER TABLE `rs_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_conn_logs`
--
ALTER TABLE `rs_conn_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_credits`
--
ALTER TABLE `rs_credits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_domains`
--
ALTER TABLE `rs_domains`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_migrations`
--
ALTER TABLE `rs_migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_packages`
--
ALTER TABLE `rs_packages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_servers`
--
ALTER TABLE `rs_servers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_servers_meta`
--
ALTER TABLE `rs_servers_meta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_settings`
--
ALTER TABLE `rs_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_sys_logs`
--
ALTER TABLE `rs_sys_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_users`
--
ALTER TABLE `rs_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_users_meta`
--
ALTER TABLE `rs_users_meta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_users_online`
--
ALTER TABLE `rs_users_online`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_users_packages`
--
ALTER TABLE `rs_users_packages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_users_subs`
--
ALTER TABLE `rs_users_subs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rs_users_traffics`
--
ALTER TABLE `rs_users_traffics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `rs_conn_logs`
--
ALTER TABLE `rs_conn_logs`
  ADD CONSTRAINT `rs_conn_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `rs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Constraints for table `rs_servers_meta`
--
ALTER TABLE `rs_servers_meta`
  ADD CONSTRAINT `rs_servers_meta_ibfk_1` FOREIGN KEY (`server_id`) REFERENCES `rs_servers` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Constraints for table `rs_users_meta`
--
ALTER TABLE `rs_users_meta`
  ADD CONSTRAINT `rs_users_meta_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `rs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Constraints for table `rs_users_online`
--
ALTER TABLE `rs_users_online`
  ADD CONSTRAINT `rs_users_online_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `rs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `rs_users_online_ibfk_2` FOREIGN KEY (`server_id`) REFERENCES `rs_servers` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Constraints for table `rs_users_packages`
--
ALTER TABLE `rs_users_packages`
  ADD CONSTRAINT `rs_users_packages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `rs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `rs_users_packages_ibfk_2` FOREIGN KEY (`package_id`) REFERENCES `rs_packages` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Constraints for table `rs_users_subs`
--
ALTER TABLE `rs_users_subs`
  ADD CONSTRAINT `rs_users_subs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `rs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Constraints for table `rs_users_traffics`
--
ALTER TABLE `rs_users_traffics`
  ADD CONSTRAINT `rs_users_traffics_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `rs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
