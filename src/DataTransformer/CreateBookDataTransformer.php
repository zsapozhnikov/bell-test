<?php

namespace App\DataTransformer;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use App\Entity\Author;
use App\Entity\Book;

class CreateBookDataTransformer implements DataTransformerInterface
{

    public function transform($object, string $to, array $context = [])
    {
        $author = new Book();
        $author->setName($object->name);

        return $author;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        if ($data instanceof Book) {
            return false;
        }

        return Book::class === $to && null !== ($context['input']['class'] ?? null);
    }
}
