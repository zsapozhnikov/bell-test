<?php

namespace App\Dto;

use Symfony\Component\Serializer\Annotation\Groups;

final class BookOutput
{
    /**
     * @Groups({"book:list", "book:item"})
     * @var int
     */
    public $id;

    /**
     * @Groups({"book:list", "book:item"})
     * @var string
     */
    public $name;

    /**
     * @Groups({"book:item"})
     */
    public $authors;
}