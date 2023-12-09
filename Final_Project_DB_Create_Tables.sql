-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema final_project_1
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema final_project_1
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `final_project_1` DEFAULT CHARACTER SET utf8 ;
USE `final_project_1` ;

-- -----------------------------------------------------
-- Table `final_project_1`.`customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `final_project_1`.`customer` (
  `id` INT NOT NULL,
  `username` VARCHAR(45) NULL,
  `first_name` VARCHAR(45) NULL,
  `last_name` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `final_project_1`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `final_project_1`.`product` (
  `id` INT NOT NULL,
  `product_name` VARCHAR(45) NULL,
  `SKU` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `final_project_1`.`review`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `final_project_1`.`review` (
  `id` INT NOT NULL,
  `rating` INT NULL,
  `comment` TEXT(250) NULL,
  `customer_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  PRIMARY KEY (`id`, `customer_id`, `product_id`),
  INDEX `fk_review_customer2_idx` (`customer_id` ASC) VISIBLE,
  INDEX `fk_review_product2_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_review_customer2`
    FOREIGN KEY (`customer_id`)
    REFERENCES `final_project_1`.`customer` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_review_product2`
    FOREIGN KEY (`product_id`)
    REFERENCES `final_project_1`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `final_project_1`.`inventory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `final_project_1`.`inventory` (
  `id` INT NOT NULL,
  `stock` INT NULL,
  `product_id` INT NOT NULL,
  PRIMARY KEY (`id`, `product_id`),
  INDEX `fk_inventory_product1_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_inventory_product1`
    FOREIGN KEY (`product_id`)
    REFERENCES `final_project_1`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `final_project_1`.`address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `final_project_1`.`address` (
  `id` INT NOT NULL,
  `address_type` VARCHAR(45) NULL,
  `address_line1` VARCHAR(45) NULL,
  `address_line2` VARCHAR(45) NULL,
  `city` VARCHAR(45) NULL,
  `state` VARCHAR(45) NULL,
  `country` VARCHAR(45) NULL,
  `postal_code` VARCHAR(45) NULL,
  `customer_id` INT NOT NULL,
  PRIMARY KEY (`id`, `customer_id`),
  INDEX `fk_address_customer2_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_address_customer2`
    FOREIGN KEY (`customer_id`)
    REFERENCES `final_project_1`.`customer` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `final_project_1`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `final_project_1`.`orders` (
  `id` INT NOT NULL,
  `order_date` DATE NULL,
  `ship_date` DATE NULL,
  `order_status` VARCHAR(45) NULL,
  `customer_id` INT NOT NULL,
  `address_id` INT NOT NULL,
  PRIMARY KEY (`id`, `customer_id`, `address_id`),
  INDEX `fk_orders_customer2_idx` (`customer_id` ASC) VISIBLE,
  INDEX `fk_orders_address2_idx` (`address_id` ASC) VISIBLE,
  CONSTRAINT `fk_orders_customer2`
    FOREIGN KEY (`customer_id`)
    REFERENCES `final_project_1`.`customer` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_address2`
    FOREIGN KEY (`address_id`)
    REFERENCES `final_project_1`.`address` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `final_project_1`.`payment_method`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `final_project_1`.`payment_method` (
  `id` INT NOT NULL,
  `payment_type` VARCHAR(45) NULL,
  `provider` VARCHAR(45) NULL,
  `account_number` VARCHAR(45) NULL,
  `expiry` VARCHAR(45) NULL,
  `customer_id` INT NOT NULL,
  `address_id` INT NOT NULL,
  PRIMARY KEY (`id`, `customer_id`, `address_id`),
  INDEX `fk_payment_method_customer2_idx` (`customer_id` ASC) VISIBLE,
  INDEX `fk_payment_method_address2_idx` (`address_id` ASC) VISIBLE,
  CONSTRAINT `fk_payment_method_customer2`
    FOREIGN KEY (`customer_id`)
    REFERENCES `final_project_1`.`customer` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_method_address2`
    FOREIGN KEY (`address_id`)
    REFERENCES `final_project_1`.`address` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `final_project_1`.`payment_details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `final_project_1`.`payment_details` (
  `id` INT NOT NULL,
  `amount` VARCHAR(45) NULL,
  `provider` VARCHAR(45) NULL,
  `payment_method_id` INT NOT NULL,
  `orders_id` INT NOT NULL,
  PRIMARY KEY (`id`, `payment_method_id`, `orders_id`),
  INDEX `fk_payment_details_payment_method1_idx` (`payment_method_id` ASC) VISIBLE,
  INDEX `fk_payment_details_orders1_idx` (`orders_id` ASC) VISIBLE,
  CONSTRAINT `fk_payment_details_payment_method1`
    FOREIGN KEY (`payment_method_id`)
    REFERENCES `final_project_1`.`payment_method` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_payment_details_orders1`
    FOREIGN KEY (`orders_id`)
    REFERENCES `final_project_1`.`orders` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `final_project_1`.`order_item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `final_project_1`.`order_item` (
  `product_id` INT NOT NULL,
  `orders_id` INT NOT NULL,
  `quantity` INT NULL,
  `price` INT NULL,
  PRIMARY KEY (`product_id`, `orders_id`),
  INDEX `fk_product_has_orders_orders2_idx` (`orders_id` ASC) VISIBLE,
  INDEX `fk_product_has_orders_product2_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_product_has_orders_product2`
    FOREIGN KEY (`product_id`)
    REFERENCES `final_project_1`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_product_has_orders_orders2`
    FOREIGN KEY (`orders_id`)
    REFERENCES `final_project_1`.`orders` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
