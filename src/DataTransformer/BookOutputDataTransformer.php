<?php

namespace App\DataTransformer;

use ApiPlatform\Core\DataTransformer\DataTransformerInterface;
use App\Dto\BookOutput;
use App\Entity\Author;
use App\Entity\Book;

class BookOutputDataTransformer implements DataTransformerInterface
{
    public function transform($object, string $to, array $context = [])
    {
        $book = new BookOutput();
        $book->id = $object->getId();
        $book->name = $object->getName();
        $book->authors = array_map(function (Author $author) {
            return [
                'id' => $author->getId(),
                'name' => $author->getName(),
            ];
        }, $object->getAuthors()->toArray());

        return $book;
    }

    public function supportsTransformation($data, string $to, array $context = []): bool
    {
        return BookOutput::class === $to && $data instanceof Book;
    }
}
