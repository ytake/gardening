<?php

/**
 * ConsoleApplication.php
 */
namespace Ytake\Gardening;

use Symfony\Component\Console\Application;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * Class ConsoleApplication
 */
class ConsoleApplication extends Application
{
    /** @var string  console application name */
    private $name = "gardening";

    /** @var float  console application version */
    private $version = 0.1;

    /**
     * ConsoleApplication constructor.
     */
    public function __construct()
    {
        parent::__construct($this->name, $this->version);
    }

    /**
     * @param InputInterface|null  $input
     * @param OutputInterface|null $output
     *
     * @return int|void
     * @throws \Exception
     */
    public function run(InputInterface $input = null, OutputInterface $output = null)
    {
        $this->addCommands([
            new \Ytake\Gardening\SetUpCommand(new \Ytake\Gardening\Foundation\Filer),
        ]);
        parent::run($input, $output);
    }
}
