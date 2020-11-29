<?php

namespace App\Dto;

use Symfony\Component\Serializer\Annotation\Groups;

final class AuthorOutput
{
    /**
     * @Groups({"author:list", "author:item"})
     * @var int
     */
    public $id;

    /**
     * @Groups({"author:list", "author:item"})
     * @var string
     */
    public $name;
}