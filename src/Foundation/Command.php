<?php

namespace Ytake\Gardening\Foundation;

use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Command\Command as SfCommand;

/**
 * Class Command
 *
 * @author  yuuki.takezawa<yuuki.takezawa@comnect.jp.net>
 * @license http://opensource.org/licenses/MIT MIT
 */
abstract class Command extends SfCommand
{
    /** @var string  command name */
    protected $command;

    /** @var string  command description */
    protected $description;

    /**
     * @return mixed
     */
    abstract protected function arguments();

    /**
     * @param InputInterface  $input
     * @param OutputInterface $output
     *
     * @return mixed
     */
    abstract protected function action(InputInterface $input, OutputInterface $output);

    /**
     * @param InputInterface  $input
     * @param OutputInterface $output
     *
     * @return void
     */
    public function execute(InputInterface $input, OutputInterface $output)
    {
        $this->action($input, $output);
    }

    /**
     * command interface configure
     *
     * @return void
     */
    public function configure()
    {
        $this->setName($this->command);
        $this->setDescription($this->description);
        $this->arguments();
    }
}
